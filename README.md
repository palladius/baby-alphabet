# 🔤 Baby Alphabet (AJ Alphabet)

On Saturday 9 January 2021, my wife told me my son Alessandro was a bit late in reading any letter of the alphabet and she urged me to do something about it. I said: *"tranquilla, leave it with me"* (which is British for *"hold my beer"*).
24 hours later, this application was built.

🌐 **Live Demo on GitHub Pages**: **[https://palladius.github.io/baby-alphabet/](https://palladius.github.io/baby-alphabet/)**

*(Also runnable as a classic Ruby on Rails / Docker / Kubernetes app — see `Dockerfile` for containerization and `kubernetes/` for Kubernetes manifests).*

To customize the Rails app, copy `.env.dist` to `.env` and tweak your settings or `kubernetes/` manifests.

## 🧠 Code Philosophy

This is a completely **stateless** program — it runs with **no database**! The entire "database" is held by the image filenames themselves, using a naming convention parsed at runtime:

<img src="https://github.com/palladius/baby-alphabet/blob/main/doc/screenshot.jpg?raw=true" width="60%" alt="Screenshot for AJ Alphabet" align="right" />

Some examples:

* `hotel.jpg`: the word is the same in UK and IT, so no biggie (`🇮🇹 🇬🇧 Hotel`).
* `barca (boat).jpg`: the system understands its primary name (Italian) is **BARCA** and its secondary name (English) is **BOAT**. You might argue about what decides what's primary and what's secondary, and I might say it's obviously alphabetical — though I'm getting into muddy waters by stating *"the developer's nationality takes precedence"*. 😉

Someday I might create a DB, as parsing files and their `WxH` dimensions on the fly was originally slow. For a few dozen images, however, it's fast, stateless, and now also pre-compiled into a zero-backend static Web App for **GitHub Pages**!

## ✨ Features (v2.10+)

* **Semi-transparent Letter Watermark (`A a` / `B b` / `C c`)**: Each card displays a crisp, semi-transparent glassmorphic badge in the top-right corner with both uppercase and lowercase letters so kids immediately associate the letter shape with the picture and word.
* **Bilingual Captions (`🇮🇹` / `🇬🇧`)**: Highlights the initial letter and shows both Italian and English words when they differ.
* **Web Speech API Pronunciation (`🔊`)**: Click the speaker icon on any card to hear the word pronounced in Italian and English.
* **Dataset Switcher**: Switch on the fly between `🍝 Vanilla (Pasta)`, `👨‍👩‍👦‍👦 AJ Family`, and `🌍 All Pics`.
* **Orientation & Alphabet Modes**: Toggle between Landscape (4 columns), Portrait ("Kate's favorite" 6 columns), Square (5 columns), and switch between the 26-letter English (`A–Z`) and 21-letter Italian (`A–Z` without `J, K, W, X, Y`) alphabets.

## 🖼️ Add Your Own Pictures

Navigate to `app/assets/images/`, where picture collections live (`vanilla/`, `ajcarlesso/`, `ajcarlesso-loads/`).
You can add your own images using the `italian_word (english_word).jpg` naming convention, or select your preferred default folder via `ALPHABET_DEFAULT_FOLDER` in `.env`.

To rebuild the static GitHub Pages site locally:

```bash
just build-static
# or directly:
ruby bin/generate_static_site.rb _site
```

## 🐳 Dockerization & Kubernetes

The Ruby on Rails application is containerized so you can build and run it locally even without a local Ruby 2.7 environment:

```bash
make docker-run
```

You can also deploy to a Kubernetes cluster (GKE) if you have Google Cloud credentials configured. Update `PROJECT_ID` in `.env` and use the included `./kubectl` wrapper (which ensures the right namespace and cluster context while preserving bash/zsh autocompletion):

```bash
make docker-push-to-gcp
```

This builds and pushes the image to Google Container Registry / Artifact Registry and refreshes the GKE deployment.

### Skaffold

To run in continuous development mode with Skaffold:

```bash
gcloud auth configure-docker
gcloud config set core/project goliardia-prod
skaffold dev
```

## 🙏 Thanks

* To my wife for creating such amazing and inspiring children (Alessandro and Sebastian), and for hitting a real jackpot by marrying me. 😉
* To Yulia for her guide on dockerizing a Rails app: [How to start your Rails app in a Docker container](https://medium.com/@yuliaoletskaya/how-to-start-your-rails-app-in-a-docker-container-9f9ce29ff6d6).
