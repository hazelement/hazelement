# hazelement

Source code for https://github.com/hazelement/hazelement.github.io

## Git branches
* `master` branch is for publishing. 
* `writing` branch is for staging new publish articles. 
* New articles should checkout from `writing` and follow this format `article/xxx`. 
* `theme` is for website theming. 
* `gh-pages` is staging branch for the actual website. 

## Publish
To publish and update the website. Create a python virtual environment with libraries in `requirements.txt`. With virtual environment activated, run the `publish.sh` script. This should compile the website with new articles and push it to GitHub. 

## Local dev

Make sure `pelican` virtualenv is activated. Use `make serve` to start a local server at port `8000`. To enable page regeneration upon changes, run `make regenerate` on a seperate window. 

To to more help, `make help`. 