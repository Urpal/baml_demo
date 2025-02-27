# baml_demo

# Setup of repo
This repo is using uv as the Python package installer and resolver.

## Install UV
Ideally install it using homebrew;
```bash
brew install uv
```
or install it any other way, see:
[uv-installation](https://docs.astral.sh/uv/getting-started/installation/)


## Install packages in directory
Move to the cloned repo and run
```bash
uv install
```

See available installed python versions
```bash
uv python list
```

Install a python version
```bash
uv python install 3.9.21
```

Change env by changing the .python-version to an available installed version and then run
```bash
uv sync
```

### BAML
Install the baml client after baml-py has been installed
```bash
uv run baml-cli init
```
if for some reason dependencies have not been synced install them manually
```bash
uv add baml-py
uv add streamlit
```
Generate the baml_client python module
```bash
uv run baml-cli generate
```
See boundary docs for more information
[baml-installation](https://docs.boundaryml.com/guide/installation-language/python)

### BAML playground
Install the VSCode extension in order to quickly run tests using BAML: [VSCode-baml](https://marketplace.visualstudio.com/items?itemName=Boundary.baml-extension) 

# How to run

## BAML playground
Play around with the files in the baml_src folder and run tests using the playground with your set API keys.

## Run demo chat interface in streamlit
Either launch the debugger or type
```bash
streamlit run app/chat_app.py
```
