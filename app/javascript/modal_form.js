import { toggleLoading } from "application";

// app/javascript/modal_form.js
export default class ModalForm {
  constructor(document, modalSelector) {
    this.document = document;
    this.modalSelector = modalSelector;
  }

  connect() {
    this.document.querySelector(this.modalSelector)
      .addEventListener('show.bs.modal', this.resetForm.bind(this));
  }

  sendRequest(event) {
    event.preventDefault()
    const form = event.target
    const formData = new FormData(form)
    const url = form.action
    const method = form.method
    const token = this.document.querySelector('meta[name="csrf-token"]').getAttribute("content");
    const body = JSON.stringify(Object.fromEntries(formData.entries()));
    const headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": token
    }

    toggleLoading();
    fetch(url, { method, headers, body }).then(response => response.json()
      .then(data => ({ status: response.status, data })))
      .then(result => {
        if (result.status === 422) {
          const errors = result.data.errors || {};

          this.renderErrors(errors, form)
        } else if (result.status >= 200 && result.status < 300) {
          window.location.reload();
        } else {
          const errorElement = document.querySelector("[data-error-for=form]")
          errorElement.classList.remove("d-none");
          errorElement.innerHTML = result.data.errors.base;
        }
      }).catch(error => console.error("Request failed:", error))
        .finally(() => toggleLoading());
  }

  resetForm(event) {
    event.target.querySelector("form").reset();

    this.document.querySelectorAll('.is-invalid').forEach(element => {
      element.classList.remove('is-invalid');
    });
  }

  renderErrors(errors, form) {
    Object.entries(errors).forEach(([field, messages]) => {
      const errorElement = form.querySelector(`[data-error-for="${field}"]`);
      if (errorElement) {
        errorElement.innerHTML = messages.join(", ");
      }
      const input = form.querySelector(`#${field}`);
      if (input) {
        input.classList.add("is-invalid");
      }
    });
  }
}
