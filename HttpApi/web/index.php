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
        'dbhost' => 'localhost',
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
 * ROUTES
 */

$app->get('/oauth/twitch/{uuid}', function($uuid) use($app) {

    return $app->redirect('https://api.twitch.tv/kraken/oauth2/authorize?response_type=code&client_id='. getenv('TWITCH_CLIENT_ID') .'&redirect_uri=http://streamcenterapp.com/oauth/redirect/twitch&scope=user_read channel_subscriptions user_subscriptions chat_login&state='. $uuid);
});

$app->post('/oauth/twitch', function(Request $request) use($app) {
    //TODO: Get POST payload containing the code to validate and return the OAuth token
});

$app->get('/oauth/redirect/twitch', function(Request $request) use($app) {

    $app['monolog']->addInfo(sprintf("REDIRECT RQST : %s", var_export($request, true)));

    $subRequest = Request::create('https://api.twitch.tv/kraken/oauth2/token', 'POST', array(
        'client_id' => getenv('TWITCH_CLIENT_ID'),
        'client_secret' => getenv('TWITCH_CLIENT_SECRET'),
        'grant_type' => 'authorization_code',
        'redirect_uri' => 'http://streamcenterapp.com/oauth/redirect/twitch',
        'code' => $request->get('code'),
        'state' => '',
    ));

    $response = $app->handle($subRequest, \Symfony\Component\HttpKernel\HttpKernelInterface::SUB_REQUEST, false);

    $app['monolog']->addInfo(sprintf("TOKEN RESPONSE : %s", var_export($request, true)));

    $jsonBody = json_encode($response->getContent());

    $token = $jsonBody['access_token'];

    //TODO: Store the token in our Database

    return new Response('TOKEN: '. $token, 200);
});


$app->run();