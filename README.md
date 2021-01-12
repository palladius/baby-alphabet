# README

On Saturday 9 January 2021, my wife told me my son Alessandro is a bit late in reading any letter of th alphabet and she uirged e to do something about it. I said: 'tranquilla, leave it with me' (which is British for hold my beer). 24 hours later this application was built.

And available on http://aj-alphabet.palladi.us/ (see Dockerfile for dockerizing it and `k8s` for the kubernitization).

To use the app, you just need to edit the .env file (TODO: move to .env.dist) and customize a bit the k8s/ file.
I'm still learning how to kustomize a YAML without recurring to helm which is a bit too overkill IMHO.
