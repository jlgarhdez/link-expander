<?php

class Crawler {

    /**
     * @var String the url of the web page to crawl
     */
    private $urlToCrawl;

    /**
     * @var String the string containing the content of the webpage
     */
    private $fullReturnedDOM;

    /**
     * @var String the pattern for extracting title
     */
    private $titlePattern = '/<title>([\s\S]+)<\/title>/i';

    /**
     * @var String the pattern for extracting the content of the first paragraph
     */
    private $paragraphPattern = '/<p>([\s\S]*?)<\/p>/i';

    /**
     * @var String the pattern for extracting the firs image of the page
     */
    private $imagePattern = '#<img[^>]*>#i';

    /**
     * from css-tricks.com
     *
     * @var String the pattern for extracting the firs image of the page
     */
    private $urlPattern= "/(http|https|ftp|ftps)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/";


    /**
     * @param $url String the URL of the page we want to crawl
     */
    public function __construct($url)
    {
        $this->urlToCrawl = $url;
    }

    public function crawl()
    {
        $curl = curl_init($this->urlToCrawl);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
        $this->fullReturnedDOM = utf8_decode(curl_exec($curl));
        curl_close($curl);
        return $this->fullReturnedDOM;
    }

    public function extractTitle()
    {
        $matches = array();

        preg_match($this->titlePattern, $this->fullReturnedDOM, $matches);

        $ret = false;

        if ($matches !== array()) {
            $ret = $matches[1];
        }

        return utf8_encode($ret);
    }

    public function extractContent()
    {
        $ret = '';

        $ret = $this->extractFirstParagraph();

        return $ret;
    }

    public function extractFirstParagraph()
    {
        $ret = false;
        $matches = array();

        preg_match($this->paragraphPattern, $this->fullReturnedDOM, $matches);

        return
            trim(
            preg_replace('/\s+/', ' ',
            utf8_encode(
            strip_tags(
                $matches[0]))));
    }

    public function extractImages()
    {
        $ret = array();
        preg_match_all($this->imagePattern, $this->fullReturnedDOM, $matches);
        $matches = $matches[0];

        foreach ($matches as $imageTag)
        {
            // Looks for the src attribute of the image
            $srcAttributePosition = strpos($imageTag, 'src="');
            $imageTag = substr($imageTag, $srcAttributePosition, -1);

            // looks for the first quote of the src attribute
            $firstQuoteAfterSrc = strpos($imageTag, '"');
            $imageTag = substr($imageTag, $firstQuoteAfterSrc, -1);
            $imageTag = substr($imageTag, 1, -1);

            // looks for the last quote of the src attribute
            $firstQuoteAfterSrc = strpos($imageTag, '"');
            $srcAttribute = substr($imageTag, 0, $firstQuoteAfterSrc);

            // Checks if the image route is relative. If so, builds a new url
            // from the relative route.
            if (!preg_match($this->urlPattern, $srcAttribute, $url)) {
                $url = parse_url($this->urlToCrawl);
                $srcAttribute = 
                    $url['scheme'] . 
                    '://' .
                    $url['host'] .
                    $srcAttribute;
            }

            $ret[] = $srcAttribute;
        }

        return $ret;
    }
}
