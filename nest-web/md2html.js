// An alternative way to using CLI commands: run the JS file below and get the .html after 
// pasting your markdown contents into `text =`

var showdown  = require('showdown'),
    converter = new showdown.Converter(),
    text      = '# hello, markdown! \
    ## These are the contents of a dummy markdown file. \
    You can paste your markdown here as it is with markdown syntax.',
    html      = converter.makeHtml(text);
