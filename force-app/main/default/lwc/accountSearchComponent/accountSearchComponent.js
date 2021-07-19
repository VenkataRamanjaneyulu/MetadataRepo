import { LightningElement, track, wire } from "lwc";
import searchAccounts from "@salesforce/apex/SearchAccount.searchAccounts";
import createContactInPanda from "@salesforce/apex/SearchAccount.createContact";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AccountSearchComponent extends LightningElement {

  @track currentAccountName;
  @track searchAccountName;

  @track accId;
  @track title;
  @track salutation;
  @track firstName;
  @track lastName;
  @track email;
  @track birthday;
  @track showCreateButton;
  @track contact;
  @track error;
  
  @track showContactForm = false;
  @track records;
  @track dataNotFound;

  @wire(searchAccounts, { keySearch: "$searchAccountName" })
  wireRecord({ data, error }) {
     console.log('data is',data);
    if (data) {
      console.log("Data-->" + JSON.stringify(data));
      this.records = data;
      this.error = undefined;
      this.dataNotFound = "";
      if (this.records === "") {
        this.dataNotFound = "There is no Account found";
        this.showContactForm = false;
      }
    } else {
      this.error = error;
      this.data = undefined;
    }
  }

  handleChange(event) {
   if (event.target.name === "title") {
     this.title = event.target.value;
   } else if (event.target.name === "fName") {
     this.firstName = event.target.value;
   } else if (event.target.name === "lName") {
     this.lastName = event.target.value;

     if (this.lastName.length === 0) {
       this.showCreateButton = false;
     } else {
       this.showCreateButton = true;
     }
   } else if (event.target.name === "salutation") {
     this.title = event.target.value;
   } else if (event.target.name === "birthday") {
     this.birthday = event.target.value;
   } else if (event.target.name === "email") {
     this.email = event.target.value;
   } else if (event.target.name === "accountName") {
     this.currentAccountName = event.target.value;
   }
 }

 handleAccountSearch() {
   this.searchAccountName = this.currentAccountName;
 }

  handleChangeRadio(event) {
    this.accId = event.target.value;
    if (this.accId !== null || this.accId !== "") {
      this.showContactForm = true;
    }
  }

  createContact() {
    console.log("createContact called");
    createContactInPanda({
      title: this.title,
      salutation: this.salutation,
      firstName: this.firstName,
      lastName: this.lastName,
      accountId: this.accId,
      email: this.email,
      bday: this.birthday
    })
      .then((result) => {
        console.log("Result block");
        this.contact = result;
        this.error = undefined;

        const evt = new ShowToastEvent({
          title: "Success",
          message: "Contact Created successfully.",
          variant: "success"
        });
        this.dispatchEvent(evt);
      })
      .catch((error) => {
        this.error = error;
        this.contact = undefined;
      });
  }

}