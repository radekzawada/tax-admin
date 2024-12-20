# Pin npm packages by running ./bin/importmap

pin "application"
pin "modal_form"
pin "popper", to: "popper.js", preload: true
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "axios", to: "https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
