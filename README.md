Link Expander
=============

Description
-----------
Simple demonstration on how to expand link description and title when pasting an
URL in a textarea.

[![default][2]][1]

  [1]: https://raw.github.com/jlgarhdez/link-expander/master/imgs/no-expanded.png
  [2]: https://raw.github.com/jlgarhdez/link-expander/master/imgs/no-expanded.png (default)

[![expanded link][4]][3]

  [3]: https://raw.github.com/jlgarhdez/link-expander/master/imgs/expanded.png
  [4]: https://raw.github.com/jlgarhdez/link-expander/master/imgs/expanded.png (expanded link)

Parts of the project
--------------------

###coffee/main.coffee
The coffee logic

###Crawler.php
The class that crawls the page looking for the title and the description.

Can be used as an autonomous class, only need to be instantiated passing the URL
we want to crawl as a parameter.

```php
$crawler = new Crawler('http://jlgarcia.me');
$crawler->crawl();

$title = $crawler->extractTitle();
$description = $crawler->extractContent();
```

###expander.php
The script that calls the Crawler

###js/main.js
The generated Javascript file (not included in the repo, needs to be generated).

Compile the Coffeescript code
-----------------------------

```bash
coffee --compile --output js/ coffee/
```
