# README

On Saturday 9 January 2021, my wife told me my son Alessandro is a bit late in reading any letter of th alphabet and she uirged e to do something about it. I said: 'tranquilla, leave it with me' (which is British for 'hold my beer.).
24 hours later this application was built.

And available on http://aj-alphabet.palladi.us/ (see Dockerfile for dockerizing it and `k8s` for the kubernitization).

To use the app, you just need to edit the .env file (TODO: move to .env.dist) and customize a bit the k8s/ file.
I'm still learning how to kustomize a YAML without recurring to helm which is a bit too overkill IMHO.

## Code filosofy

This is a completely STATELESS program, it runs with no DB. The only DB is held by the images themselves so I build a lot of complicated logic in the file naming :P

<img src="https://github.com/palladius/baby-alphabet/blob/main/doc/screenshot.jpg" width="60%" alt="Screenshot for AJ Alphabet" align='right' />

Some examples:

* `hotel.jpg`: word is the same in UK/IT so no biggie.
* `barca (boat).jpg`. The system will understand its primary name (Italian) is BARCA and its secondary name (UK) is BOAT. You might argue on what decides what's primary and what's secondary and I might say it's obvisouly alphabetical, but Im getting in muddy waters by stating "developer's nationality takes precedence".

Some day I might just create a dB as parsing files and their WxH is slow and stupid. But for 26 images its still doable :)

## Add your own pictures

Glad you've asked. Today, you need to navigate through: `app/assets/images/alphabet/`, remove my pics and add yours.I'm working on a new version where you can just create a new folder (eg `jeremy/`) and select it programmatically by changing the ENV var in `.env` and bingo, you're ready! This will come in `v1.42` or something.

## Dockerization

Code is perfectly dockerized so you can build and run locally (if you have no Ruby env on your Mac for instance):

    make docker-run
	
You can also push as k8s deployment if you have Google credentials (sorry about that - but send me a PR for AWS/Azure deployment, no big deal!)
You just need to change the project id in `.env`. I also like to use a `kubectl` wrapper around kubectl to make sure i use the right namespace and possibly
the right cluster! :) Funny enough, due to its homonimity, `./kubectl` inherits autocompletion so you can easily TAB hour way through ./kubectl get pods and so on..

Also try:

    make docker-push-to-gcp 

which pushes docker to GCR and then trhough `make up` pushes the GKE cluster to GCP. Since it's always pulling LATEST tag, if you want to refresh it it also gives you a commodity refresh command (basically kill current deployment , in GoT style).

### Skaffoldization

On xmas 2021, I've tried to add this to Skaffold.

    gcloud auth configure-docker
    gcloud config set core/project goliardia-prod
    skaffold dev

## Thanks 

* to my wife for creating such amazing and inspiring children (Alessandro and Sebastian), and for doing a real jackpot by marrying me.
* Yulia for teaching me how to dockerize a rails app (why the hell doesnt rails come with preconfigured Dockerfile?!?): https://medium.com/@yuliaoletskaya/how-to-start-your-rails-app-in-a-docker-container-9f9ce29ff6d6
