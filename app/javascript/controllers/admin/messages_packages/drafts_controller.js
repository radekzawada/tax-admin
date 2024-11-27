import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin--messages-packages--drafts"
export default class extends Controller {
  static targets = ["variable"]

  toggle(event) {
    const rowId = event.currentTarget.id.replace("draft_", "draft_variables_");
    const variableDiv = this.variableTargets.find((div) => div.id === rowId);

    const allVariableDivs = document.getElementsByClassName("draft-variables");
    Array.from(allVariableDivs).forEach(div => div.classList.add("d-none"));

    if (variableDiv) {
      variableDiv.classList.toggle("d-none");
    }
  }
}
