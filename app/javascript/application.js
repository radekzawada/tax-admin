// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "popper"
import "bootstrap"
import "controllers"

export function toggleLoading() {
  const loading = document.getElementById("spinner-overlay");
  if (loading) {
    loading.classList.toggle("d-none");
  }
}
