<?php
/**
 * Created by PhpStorm.
 * User: olivier
 * Date: 2015-10-12
 * Time: 8:24 PM
 */

require_once __DIR__.'/../vendor/autoload.php';

use Symfony\Component\HttpFoundation\Request;

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
 * ROUTES
 */

$app->get('/oauth/twitch/{uuid}', function($uuid) use($app) {
    //TODO: Redirect to the following URL
    //    https://api.twitch.tv/kraken/oauth2/authorize
    //    ?response_type=code
    //    &client_id=[your client ID] //NOTE(Olivier): This is obtained by registering our app
    //    &redirect_uri=[your registered redirect URI] NOTE(Olivier): This will be /redirect/twitch/{uuid}
    //    &scope=[space separated list of scopes]
    //    &state=[your provided unique token]
});

$app->post('/oauth/twitch', function(Request $request) use($app) {
    //TODO: Get POST payload containing the code to validate and return the OAuth token
});

$app->get('/redirect/twitch/{uuid}', function(Request $request, $uuid) use($app) {
    //TODO: Get the code from the url param ?code=
    //TODO: Query the POST https://api.twitch.tv/kraken/oauth2/token endpoint
    // This is the payload that we want to send
    //    client_id=[your client ID]
    //    &client_secret=[your client secret]
    //    &grant_type=authorization_code
    //    &redirect_uri=[your registered redirect URI]
    //    &code=[code received from redirect URI]
    //    &state=[your provided unique token]

    //TODO: Handle the response
    // Sample response
    //    {
    //        "access_token": "[user access token]",
    //        "scope":[array of requested scopes]
    //    }

    //TODO: Store the token in our Database
});


$app->run();