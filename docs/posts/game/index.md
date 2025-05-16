<!DOCTYPE html>
<html lang="en-us"><head><script src="/livereload.js?mindelay=10&amp;v=2&amp;port=1313&amp;path=livereload" data-no-instant defer></script><meta charset="utf-8">
<meta http-equiv="content-type" content="text/html">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title itemprop="name">Day trading simulator | Viny Brasil&#39;s blog</title>
<meta property="og:title" content="Day trading simulator | Viny Brasil&#39;s blog" />
<meta name="twitter:title" content="Day trading simulator | Viny Brasil&#39;s blog" />
<meta itemprop="name" content="Day trading simulator | Viny Brasil&#39;s blog" />
<meta name="application-name" content="Day trading simulator | Viny Brasil&#39;s blog" />
<meta property="og:site_name" content="Viny Brasil&#39;s blog" />

<meta name="description" content="Game built with Raylib and WASM">
<meta itemprop="description" content="Game built with Raylib and WASM" />
<meta property="og:description" content="Game built with Raylib and WASM" />
<meta name="twitter:description" content="Game built with Raylib and WASM" />

<meta property="og:locale" content="en-us" />
<meta name="language" content="en-us" />

  <link rel="alternate" hreflang="en-us" href="http://localhost:1313/posts/game/" title="English" />





    
    
    

    <meta property="og:type" content="article" />
    <meta property="og:article:published_time" content=0001-01-01T00:00:00Z />
    <meta property="article:published_time" content=0001-01-01T00:00:00Z />
    <meta property="og:url" content="http://localhost:1313/posts/game/" />

    
    <meta property="og:article:author" content="Vinicyus Brasil" />
    <meta property="article:author" content="Vinicyus Brasil" />
    <meta name="author" content="Vinicyus Brasil" />
    
    

    

    <script defer type="application/ld+json">
    {
        "@context": "http://schema.org",
        "@type": "Article",
        "headline": "Day trading simulator",
        "author": {
        "@type": "Person",
        "name": ""
        },
        "datePublished": "0001-01-01",
        "description": "Game built with Raylib and WASM",
        "wordCount":  3 ,
        "mainEntityOfPage": "True",
        "dateModified": "0001-01-01",
        "image": {
        "@type": "imageObject",
        "url": ""
        },
        "publisher": {
        "@type": "Organization",
        "name": "Viny Brasil\u0027s blog"
        }
    }
    </script>


<meta name="generator" content="Hugo 0.147.3">

    
    <meta property="og:url" content="http://localhost:1313/posts/game/">
  <meta property="og:site_name" content="Viny Brasil&#39;s blog">
  <meta property="og:title" content="Day trading simulator">
  <meta property="og:description" content="Game built with Raylib and WASM">
  <meta property="og:locale" content="en_us">
  <meta property="og:type" content="article">
    <meta property="article:section" content="posts">


    
    
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Day trading simulator">
  <meta name="twitter:description" content="Game built with Raylib and WASM">


    

    <link rel="canonical" href="http://localhost:1313/posts/game/">
    <link href="/style.min.42e37435fa386b24c4c2ba533734722ef928d7f110c4e2a59f8b1aed70a21b34.css" rel="stylesheet">
    <link href="/code-highlight.min.706d31975fec544a864cb7f0d847a73ea55ca1df91bf495fd12a177138d807cf.css" rel="stylesheet">

    
    <link rel="apple-touch-icon" sizes="180x180" href="/icons/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/icons/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/icons/favicon-16x16.png">
    <link rel="mask-icon" href="/icons/safari-pinned-tab.svg">
    <link rel="shortcut icon" href="/favicon.ico">




<link rel="manifest" href="http://localhost:1313/site.webmanifest">

<meta name="msapplication-config" content="/browserconfig.xml">
<meta name="msapplication-TileColor" content="#2d89ef">
<meta name="theme-color" content="#434648">

    
    <link rel="icon" type="image/svg+xml" href="/icons/favicon.svg">

    
    
</head>
<body data-theme = "dark" class="notransition">

<script src="/js/theme.js"></script>

<div class="navbar" role="navigation">
    <nav class="menu" aria-label="Main Navigation">
        <a href="http://localhost:1313/" class="logo">
            <svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" 
viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" 
stroke-linejoin="round" class="feather feather-home">
<title>Home</title>
<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
<polyline points="9 22 9 12 15 12 15 22"></polyline>
</svg>
        </a>
        <input type="checkbox" id="menu-trigger" class="menu-trigger" />
        <label for="menu-trigger">
            <span class="menu-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" stroke="currentColor" fill="none" viewBox="0 0 14 14"><title>Menu</title><path stroke-linecap="round" stroke-linejoin="round" d="M10.595 7L3.40726 7"></path><path stroke-linecap="round" stroke-linejoin="round" d="M10.5096 3.51488L3.49301 3.51488"></path><path stroke-linecap="round" stroke-linejoin="round" d="M10.5096 10.4851H3.49301"></path><path stroke-linecap="round" stroke-linejoin="round" d="M0.5 12.5V1.5C0.5 0.947715 0.947715 0.5 1.5 0.5H12.5C13.0523 0.5 13.5 0.947715 13.5 1.5V12.5C13.5 13.0523 13.0523 13.5 12.5 13.5H1.5C0.947715 13.5 0.5 13.0523 0.5 12.5Z"></path></svg>
            </span>
        </label>

        <div class="trigger">
            <ul class="trigger-container">
                
                
                <li>
                    <a class="menu-link " href="/">
                        Home
                    </a>
                    
                </li>
                
                <li>
                    <a class="menu-link active" href="/posts/">
                        Posts
                    </a>
                    
                </li>
                
                <li>
                    <a class="menu-link " href="/pages/videos/">
                        Videos
                    </a>
                    
                </li>
                
                <li>
                    <a class="menu-link " href="/pages/about/">
                        Research
                    </a>
                    
                </li>
                
                <li>
                    <a class="menu-link " href="https://www.linkedin.com/in/vinicyus-brasil/?locale=en_US">
                        Linkedin
                    </a>
                    
                </li>
                
                <li>
                    <a class="menu-link " href="https://github.com/vinybrasil">
                        Github
                    </a>
                    
                </li>
                
                <li class="menu-separator">
                    <span>|</span>
                </li>
                
                
            </ul>
            <a id="mode" href="#">
                <svg xmlns="http://www.w3.org/2000/svg" class="mode-sunny" width="21" height="21" viewBox="0 0 14 14" stroke-width="1">
<title>LIGHT</title><g><circle cx="7" cy="7" r="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round"></circle><line x1="7" y1="0.5" x2="7" y2="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="2.4" y1="2.4" x2="3.82" y2="3.82" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="0.5" y1="7" x2="2.5" y2="7" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="2.4" y1="11.6" x2="3.82" y2="10.18" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="7" y1="13.5" x2="7" y2="11.5" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="11.6" y1="11.6" x2="10.18" y2="10.18" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="13.5" y1="7" x2="11.5" y2="7" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="11.6" y1="2.4" x2="10.18" y2="3.82" fill="none" stroke-linecap="round" stroke-linejoin="round"></line></g></svg>
                <svg xmlns="http://www.w3.org/2000/svg" class="mode-moon" width="21" height="21" viewBox="0 0 14 14" stroke-width="1">
<title>DARK</title><g><circle cx="7" cy="7" r="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round"></circle><line x1="7" y1="0.5" x2="7" y2="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="2.4" y1="2.4" x2="3.82" y2="3.82" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="0.5" y1="7" x2="2.5" y2="7" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="2.4" y1="11.6" x2="3.82" y2="10.18" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="7" y1="13.5" x2="7" y2="11.5" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="11.6" y1="11.6" x2="10.18" y2="10.18" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="13.5" y1="7" x2="11.5" y2="7" fill="none" stroke-linecap="round" stroke-linejoin="round"></line><line x1="11.6" y1="2.4" x2="10.18" y2="3.82" fill="none" stroke-linecap="round" stroke-linejoin="round"></line></g></svg>
            </a>
        </div>
    </nav>
</div>

<div class="wrapper post">
    <main class="page-content" aria-label="Content">
        <article>
            <header class="header">
                <h1 class="header-title">Day trading simulator</h1>
                
                
            </header>
            
            <div class="page-content">
                

<style>
    /* Remove default margins and padding */
    body {
        margin: 0;
        padding: 0;
        background-color: #000;
    }

    /* Main container that centers everything */
    .game-centerer {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        width: 100%;
    }

    /* Container that holds the game with border */
    .game-border {
        border: 4px solid #333;
        border-radius: 8px;
        overflow: hidden; /* Ensures border contains everything */
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
    }

    /* Game canvas styling */
    canvas.emscripten {
        display: block; /* Removes extra space around canvas */
        background-color: #000;
    }
</style>
<!-- <div class="center-rectangle"> -->

<div class="game-wrapper">
    <div class="game-container">


        <html lang=EN-us>

        <head>
            <meta charset=utf-8>
            <meta content="text/html; charset=utf-8" http-equiv=Content-Type>
            <title>raylib web game</title>
            <meta content="raylib web game" name=title>
            <meta content="New raylib web videogame, developed using raylib videogames library" name=description>
            <meta content="raylib, programming, examples, html5, C, C++, library, learn, games, videogames"
                name=keywords>
            <meta content="width=device-width" name=viewport>
            <meta content=website property=og:type>
            <meta content="raylib web game" property=og:title>
            <meta content=image/png property=og:image:type>
            <meta content=https://www.raylib.com/common/raylib_logo.png property=og:image>
            <meta content="New raylib web videogame, developed using raylib videogames library" property=og:image:alt>
            <meta content="raylib - example" property=og:site_name>
            <meta content=https://www.raylib.com/games.html property=og:url>
            <meta content="New raylib web videogame, developed using raylib videogames library" property=og:description>
            <meta content=summary_large_image name=twitter:card>
            <meta content=@raysan5 name=twitter:site>
            <meta content="raylib web game" name=twitter:title>
            <meta content=https://www.raylib.com/common/raylib_logo.png name=twitter:image>
            <meta content="New raylib web videogame, developed using raylib videogames library" name=twitter:image:alt>
            <meta content=https://www.raylib.com/games.html name=twitter:url>
            <meta content="New raylib web videogame, developed using raylib videogames library"
                name=twitter:description>
            <link href=https://www.raylib.com/favicon.ico rel="shortcut icon">
            <style>
                body {
                    margin: 0;
                    overflow: hidden;
                    background-color: #000
                }

                canvas.emscripten {
                    border: 0 none;
                    background-color: #000
                }
            </style>
            <script src=https://cdn.jsdelivr.net/gh/eligrey/FileSaver.js/dist/FileSaver.min.js></script>
            <script>function saveFileFromMEMFSToDisk(e, a) { var i, o = FS.readFile(e); i = new Blob([o.buffer], { type: "application/octet-binary" }), saveAs(i, a) }</script>
        </head>

        <body><canvas class=emscripten id=canvas oncontextmenu=event.preventDefault() tabindex=-1></canvas>
            <p id=output>
                <script>var Module = { print: function () { var e = document.getElementById("output"); return e && (e.value = ""), function (n) { arguments.length > 1 && (n = Array.prototype.slice.call(arguments).join(" ")), console.log(n), e && (e.value += n + "\n", e.scrollTop = e.scrollHeight) } }(), canvas: document.getElementById("canvas") }</script>
                <script src=index.js async></script>
        </body>

        </html>

        </div>
</div>
            </div>
        </article></main>
</div>
<footer class="footer">
    <span class="footer_item"> </span>
    &nbsp;

    <div class="footer_social-icons">
<a href="https://github.com/vinybrasil" target="_blank" rel="noopener noreferrer me"
    title="Github">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round">
    <path
        d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22">
    </path>
</svg>
</a>
<a href="/index.xml" target="_blank" rel="noopener noreferrer me"
    title="Rss">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round">
    <path d="M4 11a9 9 0 0 1 9 9" />
    <path d="M4 4a16 16 0 0 1 16 16" />
    <circle cx="5" cy="19" r="1" />
</svg>
</a>
</div>
    <small class="footer_copyright">
        © 2025 Vinicyus Brasil.
        Powered by <a href="https://github.com/hugo-sid/hugo-blog-awesome" target="_blank" rel="noopener">Hugo blog awesome</a>.
    </small>
</footer><a href="#" title="Go to top" id="totop">
    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="currentColor" stroke="currentColor" viewBox="0 96 960 960">
    <path d="M283 704.739 234.261 656 480 410.261 725.739 656 677 704.739l-197-197-197 197Z"/>
</svg>

</a>


    






    
    <script async src="http://localhost:1313/js/main.js" ></script>

    

</body>
</html>



## The math 

