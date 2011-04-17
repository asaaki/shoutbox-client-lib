<?php
/*
  shout.php - A shoutbox.io PHP client class

Description:  A shoutbox.io client class for PHP5
Version:      0.1.0
Author:       Christoph Grabo, <chris@dinarrr.com>
License:      MIT/X11
*/

/*
  Usage:

  $shtbx = new ShoutboxClient();
  $shtbx->setAuthToken("<YOUR_AUTH_TOKEN>");
  $shtbx->shout(array(
    'status'      =>  'green',
    'name'        =>  'MyTask',
    'message'     =>  'MyMessage',
    'group'       =>  'MyGroup',
    'expires_in'  =>  seconds,
    'options'     =>  array()
  ));
  or
  $shtbx->shout('green','MyTask','MyMessage','MyGroup',seconds,array());

*/

/**
 * Class ShoutboxClient
 *
 * @license http://url-to-mit-license MIT/X11
**/
class ShoutboxClient {

  private $cgf  = array();
  private $args = array();
  private $zend_client = null;

  public function __construct() {
    $this->init();
    $this->config();
    return true;
  } #__construct
  
  private function init() {
    if( function_exists("curl_init") ) {
      #echo "native PHP curl lib installed.\n"; #DBG
      $this->cfg['http_lib'] = 'curl';
    } else {
      #echo "no curl found! we use Zend_Http_Client lib.\n"; #DBG
      $this->cfg['http_lib'] = 'zend';
    }
    return true;
  } #init
  
  private function config() {
    $this->cfg['default_group'] = 'Home'; # we MUST set a group!
    $this->cfg['host']          = "http://shoutbox.io";
    $this->cfg['port']          = null; # means: default usage of port 80
    $this->cfg['path']          = "/status";
    $this->cfg['auth_token']    = "invalid-auth-token";
    $this->cfg['proxy_host']    = null;
    $this->cfg['proxy_port']    = null;
    $this->cfg['user_agent']    = 'php shoutbox client (+https://github.com/asaaki/shoutbox-client-lib)';
    return true;
  } #config
  
  public function configure($key,$value) {
    $this->cfg[$name] = $value;
    return true;
  } #configure
  
  public function setAuthToken($token) {
    $this->cfg['auth_token'] = $token;
    if( $token === $this->cfg['auth_token'] ) return true;
    return false;
  } #configure
  
  public function shout() {
    if( func_num_args()==1 && is_array(func_get_arg(0)) ) {
      $this->shout_array( func_get_arg(0) );
      return true;
    } elseif ( func_num_args() > 1 ) {
      $this->shout_strings( func_get_args() );
      return true;
    } else {
      echo "::shout ERROR! - args inappropriate."; #DBG
      return false;
    } #if
  } #shout
  
  private function shout_array( $args ) {
    $this->args = $args;
    $this->do_shout();
    return true;
  } #shout_array
  
  private function shout_strings( $args ) {
    switch( count($args) ) {
      case 6:
        if( !empty($args[5]) && is_array($args[5]) )
          $this->args['options'] = $args[5] ;
      case 5:
        if( !empty($args[4]) ) $this->args['expires_in'] =  $args[4] ;
      case 4:
        if( !empty($args[3]) ) $this->args['group']      =  $args[3] ;
      case 3:
        if( !empty($args[2]) ) $this->args['message']    =  $args[2] ;
      case 2:
        if( !empty($args[1]) ) $this->args['name']       =  $args[1] ;
      case 1:
        if( !empty($args[0]) ) $this->args['status']     =  $args[0] ;
        break;
      default:
        echo "::shout_strings ERROR! - no args provided!"; #DBG
        return false;
    }
    $this->do_shout();
    return true;
  } #shout_strings
  
  private function do_shout() {
    extract($this->cfg,EXTR_PREFIX_ALL,'cfg');
    
    $json_data = array();
    $data = array_merge(
      array('group'=>$cfg_default_group),
      $this->args
    );
    foreach($data as $k => $v){
      if(!is_array($v)) # prevents usage of options array
        $json_data[] = '"'.$k.'":"'.$v.'"';
    }
    $json = "{".implode(',',$json_data)."}";
    
    $uri = "";
    if( isset($cfg_port) && !empty($cfg_port) ) {
      $uri = $cfg_host.':'.$cgf_port.$cfg_path;
    } else {
      $uri = $cfg_host.$cfg_path;
    }
    
    #$cfg_http_lib = 'zend'; #DBG
    
    if( $cfg_http_lib == 'curl' ){
      $c = curl_init();
      
      $c_put_data = fopen('php://memory', 'rw'); # minimum PHP 5.1.0!
      fwrite($c_put_data,$json);
      rewind($c_put_data);
      
      $c_opt = array(
        CURLOPT_URL         => $uri,
        CURLOPT_USERAGENT   => $cfg_user_agent.' [libcurl]',
        CURLOPT_HTTPHEADER  => array(
          'Content-Type: application/json',
          'Accept: application/json',
          'X-Shoutbox-Auth-Token: '.$cfg_auth_token),
        CURLOPT_ENCODING    => 'gzip',
        CURLOPT_PUT         => true,
        CURLOPT_INFILE      => $c_put_data,
        CURLOPT_INFILESIZE  => strlen($json),
        CURLOPT_RETURNTRANSFER => true
      );
      
      curl_setopt_array($c,$c_opt);
      $cr = curl_exec($c);
      curl_close($c);
      
      if( $cr === 'OK' ) return true;
      return false;
      
    } elseif( $cfg_http_lib == 'zend' ) {
      
      $this->loadZendHttpClient();
      $z = $this->zend_client;
      
      $z->setUri($uri);
      $z->setConfig(array(
        'useragent' => $cfg_user_agent.' [ZendHttpClient lib]',
        'timeout' => 3
      ));
      $z->setHeaders(array(
        'Content-Type: application/json',
        'Accept: application/json',
        'X-Shoutbox-Auth-Token: '.$cfg_auth_token));
      $z->setRawData($json, 'application/json');
      $z->setMethod(Zend_Http_Client::PUT);
      $zr = $z->request();

      if( $zr === 'OK' ) return true;
      return false;
      
    } else {
      # do dry-run: prints only json data
      #echo "doing dry-run ...\n"; #DBG
      echo "JSON:\n".$json."\n"; #DBG
    }
    
    
    return true;
  } #do_shout
  
  // some helpers
  
  public function green() {
    if( func_num_args()==1 && is_array(func_get_arg(0)) ) {
      $in = array_merge( func_get_arg(0), array('status'=>'green') ); 
      $this->shout_array( $in );
      return true;
    } elseif ( func_num_args() >= 1 ) {
      $in = array_merge( array('green'), func_get_args() );
      $this->shout_strings( $in );
      return true;
    } else {
      echo "::green ERROR! - args inappropriate."; #DBG
      return false;
    } #if
  } #green
  
  public function yellow( $in ) {
    if( func_num_args()==1 && is_array(func_get_arg(0)) ) {
      $in = array_merge( func_get_arg(0), array('status'=>'yellow') ); 
      $this->shout_array( $in );
      return true;
    } elseif ( func_num_args() >= 1 ) {
      $in = array_merge( array('yellow'), func_get_args() );
      $this->shout_strings( $in );
      return true;
    } else {
      echo "::yellow ERROR! - args inappropriate."; #DBG
      return false;
    } #if
  } #yellow
  
  public function red( $in ) {
    if( func_num_args()==1 && is_array(func_get_arg(0)) ) {
      $in = array_merge( func_get_arg(0), array('status'=>'red') ); 
      $this->shout_array( $in );
      return true;
    } elseif ( func_num_args() >= 1 ) {
      $in = array_merge( array('red'), func_get_args() );
      $this->shout_strings( $in );
      return true;
    } else {
      echo "::red ERROR! - args inappropriate."; #DBG
      return false;
    } #if
  } #red
  
  public function remove( $in ) {
    if( func_num_args()==1 && is_array(func_get_arg(0)) ) {
      $in = array_merge( func_get_arg(0), array('status'=>'remove') ); 
      $this->shout_array( $in );
      return true;
    } elseif ( func_num_args() >= 1 ) {
      $in = array_merge( array('remove'), func_get_args() );
      $this->shout_strings( $in );
      return true;
    } else {
      echo "::remove ERROR! - args inappropriate."; #DBG
      return false;
    } #if
  } #remove

  private function loadZendHttpClient() {
    $load_path = realpath(dirname(__FILE__)).'/';
    require_once $load_path.'Zend/Loader.php';
    require_once $load_path.'Zend/Validate/Interface.php';
    require_once $load_path.'Zend/Validate/Abstract.php';
    require_once $load_path.'Zend/Validate/Ip.php';
    require_once $load_path.'Zend/Validate/Hostname.php';
    require_once $load_path.'Zend/Uri.php';
    require_once $load_path.'Zend/Http/Client/Adapter/Interface.php';
    require_once $load_path.'Zend/Http/Client/Adapter/Stream.php';
    require_once $load_path.'Zend/Http/Client/Adapter/Socket.php';
    require_once $load_path.'Zend/Http/Response.php';
    require_once $load_path.'Zend/Http/Response/Stream.php';
    require_once $load_path.'Zend/Http/Client.php';
    $this->zend_client = new Zend_Http_Client();
  }

} #class

?>
