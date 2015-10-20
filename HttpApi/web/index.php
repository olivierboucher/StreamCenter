<?php
/**
 * Created by PhpStorm.
 * User: olivier
 * Date: 2015-10-12
 * Time: 8:24 PM
 */

require_once __DIR__.'/../vendor/autoload.php';

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/*
 * FOR DEVELOPMENT PURPOSES
 * SETS UP URLS ON PHP BUILT-IN SERVER
 */
$filename = __DIR__.preg_replace('#(\?.*)$#', '', $_SERVER['REQUEST_URI']);
if (php_sapi_name() === 'cli-server' && is_file($filename)) {
    return false;
}

//Used for logging
$DEV = true;

$app = new Silex\Application();

if ($DEV) {
    $app['debug'] = true;
}

/*
 * DATABASE SETUP
 */

$app->register(new Silex\Provider\DoctrineServiceProvider(), array(
    'db.options' => array(
        'driver' => 'pdo_mysql',
        'dbhost' => '127.0.0.1',
        'dbname' => 'stream_center',
        'user' => 'streamcenterapi',
        'password' => getenv('STREAMCENTER_API_MYSQLPWD'),
    ),
));

/*
 * LOGGING
 */

if($DEV){
    $app->register(new Silex\Provider\MonologServiceProvider(), array(
        'monolog.logfile' => '/home/olivier/stream_center_dev.log',
    ));
}
else{
    $app->register(new Silex\Provider\MonologServiceProvider(), array(
        'monolog.logfile' => '/home/olivier/stream_center_prod.log',
    ));
}

/*
 * VIEW RENDERING
 */

$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path' => __DIR__.'/views',
));

/*
 * SESSION
 */

$app->register(new Silex\Provider\SessionServiceProvider());
$app['session']->start();

/*
 * ROUTES
 */

$app->get('/', function(Request $request) use($app) {
    return $app['twig']->render('index.twig');
});

$app->get('/customurl', function(Request $request) use($app) {
    $csrfToken = md5(uniqid(rand(), true));
    $app['session']->set('csrf_token', $csrfToken);
    return $app['twig']->render('acceptUrl.twig', array(
        'csrf_token' => $csrfToken,
    ));
});

$app->post('/customurl', function(Request $request) use ($app) {
    $csrfCheck = $request->get('csrfToken') === $app['session']->get('csrf_token');

    if($csrfCheck){
        $url = $request->get('urlInput');
        if (!filter_var($url, FILTER_VALIDATE_URL) === false) {

            $stmt = $app['db']->prepare('SELECT addNewCustomURL(:url)');
            $stmt->bindValue("url", $url);
            $stmt->execute();

            $code = $stmt->fetchColumn(0);

            return $app['twig']->render('displayCode.twig', array(
                'accessCode' => $code,
            ));

        } else {
	        return $app['twig']->render('displayError.twig', array(
		    	"message" => "Provided url is invalid",
                "backUrl" => "/customurl",
			));
        }
    }
    else {
        return $app->json(array(
            "error" => "Bad request",
            "message" => "Invalid CSRF token"
        ), 400);
    }
});

$app->get('/customurl/{code}', function(Request $request, $code) use($app) {
    $stmt = $app['db']->prepare('SELECT * FROM custom_urls WHERE code=:code');
    $stmt->bindValue("code", $code);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row != false) {
        return $app->json(array(
            'id' => $row['id'],
            'url' => $row['url'],
            'generated_date' => $row['generated_date'],
        ), 200);
    }
    else {
        return $app->json(array(
            "error" => "Not found",
            "message" => "The provided code did not match any stored url."
        ), 404);
    }
});

$app->get('/oauth/twitch/{uuid}', function($uuid) use($app) {

    return $app->redirect('https://api.twitch.tv/kraken/oauth2/authorize?response_type=code&client_id='. getenv('TWITCH_CLIENT_ID') .'&redirect_uri=http://streamcenterapp.com/oauth/redirect/twitch&scope=user_read channel_subscriptions user_subscriptions chat_login user_follows_edit&state='. $uuid);
});

$app->get('/oauth/twitch/{uuid}/{access_code}', function(Request $request, $uuid, $access_code) use($app) {

    $stmt = $app['db']->prepare('SELECT access_token, refreshed_date FROM oauth_requests WHERE uuid=:uuid AND platform=:platform AND access_code=:access_code');
    $stmt->bindValue("uuid", $uuid);
    $stmt->bindValue("platform", 'TWITCH');
    $stmt->bindValue("access_code", $access_code);
    $stmt->execute();

    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    $app['monolog']->addInfo(sprintf("ACCESS TOKEN REQUEST RESULT : %s", var_export($row, true)));

    if ($row != false) {
        return $app->json(array(
            'access_token' => $row['access_token'],
            'generated_date' => $row['refreshed_date'],
        ), 200);
    }
    else {
        return $app->json(array(
            "error" => "Unauthorized",
            "message" => "Please authenticate at http://streamcenterapp.com/oauth/twitch/{device_uuid} or provide a valid access_code."
        ), 401);
    }
});


$app->post('/oauth/twitch/refresh', function(Request $request) use($app) {
    //TODO: Use the refresh token to generate a new token
    //NOTE(Olivier): Twitch does not expire tokens yet so do not bother implementing this
});

$app->get('/oauth/redirect/twitch', function(Request $request) use($app) {

    $uuid = $request->get('state');

    $postBody = array(
        'client_id' => getenv('TWITCH_CLIENT_ID'),
        'client_secret' => getenv('TWITCH_CLIENT_SECRET'),
        'grant_type' => 'authorization_code',
        'redirect_uri' => 'http://streamcenterapp.com/oauth/redirect/twitch',
        'code' => $request->get('code'),
        'state' => $uuid,
    );

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL,"https://api.twitch.tv/kraken/oauth2/token");
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($postBody));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $response = json_decode(curl_exec($ch), true);
    curl_close($ch);

    $app['monolog']->addInfo(sprintf("TOKEN RESPONSE : %s", var_export($response, true)));


    $accessToken = $response["access_token"];
    $refreshToken = $response["refresh_token"];

    //Check if a record exists, if so, replace it
    $stmt = $app['db']->prepare('SELECT COUNT(*) FROM oauth_requests WHERE uuid=:uuid AND platform=:platform');
    $stmt->bindValue("uuid", $uuid);
    $stmt->bindValue("platform", 'TWITCH');
    $stmt->execute();

    $count = $stmt->fetchColumn(0);
    $app['monolog']->addInfo("FOUND $count RECORDS FOR UUID: $uuid");

    $accessCode = substr(md5(microtime()),rand(0,26),5);
    $app['monolog']->addInfo("GENERATED NEW ACCESS CODE: $accessCode FOR UUID: $uuid");

    if($count == 0) {
        $stmt = $app['db']->prepare('INSERT INTO oauth_requests(uuid, platform, access_token, refresh_token, refreshed_date, access_code) VALUES(:uuid, :platform, :access_token, :refresh_token, :refreshed_date, :access_code)');
        $stmt->bindValue("uuid", $uuid);
        $stmt->bindValue("platform", 'TWITCH');
        $stmt->bindValue("access_token", $accessToken);
        $stmt->bindValue("refresh_token", $refreshToken);
        $stmt->bindValue("refreshed_date", new DateTime(), 'datetime');
        $stmt->bindValue("access_code", $accessCode);

        $stmt->execute();
        $app['monolog']->addInfo("INSERTED NEW TOKEN: $accessToken for UUID: $uuid");
    } else {
        $stmt = $app['db']->prepare('UPDATE oauth_requests SET uuid=:uuid, platform=:platform, access_token=:access_token, refresh_token=:refresh_token, refreshed_date=:refreshed_date, access_code=:access_code WHERE uuid=:uuid AND platform=:platform');
        $stmt->bindValue("uuid", $uuid);
        $stmt->bindValue("platform", 'TWITCH');
        $stmt->bindValue("access_token", $accessToken);
        $stmt->bindValue("refresh_token", $refreshToken);
        $stmt->bindValue("refreshed_date", new DateTime(), 'datetime');
        $stmt->bindValue("access_code", $accessCode);

        $stmt->execute();
        $app['monolog']->addInfo("UPDATED NEW TOKEN: $accessToken for UUID: $uuid");
    }

    return $app['twig']->render('displayCode.twig', array(
        'accessCode' => $accessCode,
    ));
});

$app->error(function (\Exception $e, $code) use ($app) {
    switch ($code) {
        case 404:
            return $app['twig']->render('display404.twig');
            break;
        default:
            return $app['twig']->render('displayError.twig', array(
                "message" => "We are sorry, an unknown error happened.",
                "backUrl" => "/",
            ));
    }
});


$app->run();