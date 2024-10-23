import { Controller } from "@hotwired/stimulus"
import ModalForm from "modal_form";

// Connects to data-controller="admin-messages-packages-create-message"
export default class extends Controller {
  connect() {
    this.modalForm = new ModalForm(document, "#new_package_modal");
    this.modalForm.connect();
  }

  submit(event) {
    this.modalForm.sendRequest(event);
  }
}
