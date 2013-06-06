<?php

/**
* @author José Luis García <jlgarcia.me>
* @license MIT <https://raw.github.com/jlgarhdez/link-expander/master/LICENSE>
*/
class Crawler {

    /**
     * @var String the url of the web page to crawl
     */
    public $urlToCrawl;

    /**
     * @var String the string containing the content of the webpage
     */
    public $fullReturnedDOM;

    /**
     * @var String the string containing the content of the webpage
     */
    public $parsedDOM;

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
        $this->parsedDOM = new \DomDocument();
        $this->parsedDOM->loadHTML($this->fullReturnedDOM);
        $this->parsedDOM->preservedWhiteSpace = false;

        return $this->fullReturnedDOM;
    }

    /**
     * Returns the title of the page if exists. If it doesn't exists, return the
     * <h1> content
     *
     * @return string the title of the page
     */
    public function extractTitle()
    {
        $title = $this->parsedDOM->getElementsByTagName('title')->item(0);

        if (
            $title !== null
            && $title->nodeValue !== ''
        ) {
            return $title->nodeValue;
        } else {
            return
                $this
                ->parsedDOM
                ->getElementsByTagName('h1')
                ->item(0)
                ->nodeValue;
        }
    }

    /**
     * Looks for the most relevant content excerpt of the page. For extracting
     * the most relevant excerpt follows the next steps:
     *
     * 1. Check if the page layout is OpenGraph compliant and get the
     *    description if so.
     * 2. If the page is not OG compliant, tries to get the meta description.
     * 3. If the page has not meta description tag but has html5 layout, look 
     *    for the first <p> inside the first <article>
     * 4. If the page does not have any <article> tag, returns the first
     *    paragraph
     * 5. Return the bare text inside the body tag.
     *
     * @return string the most relevant description
     */
    public function extractContent()
    {
        $metas = $this->parsedDOM->getElementsByTagName('meta');

        // If exists meta-description, uses it
        foreach ($metas as $meta)
        {
            // Loops the list of attributes
            foreach ($meta->attributes as $attribute)
            {

                // Checks if the page is OG Compliant
                if ($attribute->name == 'name'
                    && $attribute->value == 'og:description'
                    && $meta->attributes->getNamedItem('content')->value !== ''
                ) {
                    // Returns the og:description
                    return trim($meta->attributes->getNamedItem('content')->value);
                }

                // looks for the description meta tag
                if ($attribute->name == 'name'
                    && $attribute->value == 'description'
                    && $meta->attributes->getNamedItem('content')->value !== ''
                ) {
                    return trim($meta->attributes->getNamedItem('content')->value);
                }
            }
        }

        $article = $this->parsedDOM->getElementsByTagName('article')->item(0);

        if ($article !== null ) {
            // Search the first paragraph inside the article
            $paragraph = $article->firstChild->nodeValue;
            return trim($paragraph);

        }

        $paragraph = $this
                ->parsedDOM
                ->getElementsByTagName('p')
                ->item(0);

        if ($paragraph !== null) {
            return trim($paragraph);
        }

        return trim($this
            ->parsedDOM
            ->getElementsByTagName('body')
            ->item(0)
            ->nodeValue);
    }

    public function extractImages()
    {
        $urlInfo = parse_url($this->urlToCrawl);
        $images = $this->parsedDOM->getElementsByTagName('img');
        $urlPattern= "/(http|https|ftp|ftps)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/";
        $imageUrlList = array();

        foreach ($images as $image) 
        {
            foreach ($image->attributes as $attribute) 
            {
                if ($attribute->name == 'src') {
                    if (!preg_match($urlPattern, $attribute->value, $trash)){
                        $imageUrlList[] =
                            $urlInfo['scheme'] . 
                            '://' .
                            $urlInfo['host'] .
                            $attribute->value;
                    }else{
                        $imageUrlList[] = $attribute->value;
                    }
                }
            }
        }
        return $imageUrlList;
    }
}
