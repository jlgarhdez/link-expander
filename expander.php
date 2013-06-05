<?php
/**
* @author José Luis García <jlgarcia.me>
* @license MIT <https://raw.github.com/jlgarhdez/link-expander/master/LICENSE>
*/

include 'Crawler.php';

$url = 
    (isset($_GET['url']))
    ? $_GET['url']
    : null ;

$crawler = new Crawler($url);

$crawler->crawl();

$return = array();
$return['url'] = $url;
$return['title'] = trim($crawler->extractTitle());
$return['description'] = $crawler->extractContent();
$return['images'] = $crawler->extractImages();

header('Content-type: application/json');
echo json_encode($return);
