import { Controller } from "@hotwired/stimulus"
import ModalForm from "modal_form";

// Connects to data-controller="admin-mailbox-configure-template"
export default class extends Controller {
  connect() {
    this.modalForm = new ModalForm(document, "#addFileTemplateModal");
    this.modalForm.connect();
  }

  submit(event) {
    this.modalForm.sendRequest(event);
  }
}
