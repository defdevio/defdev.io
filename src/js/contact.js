let submitUrl = 'https://vh4tf5xws5.execute-api.us-west-2.amazonaws.com/prod/contact';
const form = document.getElementById('contact');
const contactCloseBtn = document.getElementById('contact-close-btn');
const cfTurnstile = document.getElementById('cf-turnstile');
const submitBtn = document.getElementById('submit-btn');
const submitSendingBtn = document.getElementById('submit-send-btn');
const successBtn = document.getElementById('success-btn')
const errorBtn = document.getElementById('error-btn')
const modalHeader = document.getElementById('modal-header')
const modalForm = document.getElementById('modal-form')
const successEmail = document.getElementById('success-email')

form.addEventListener('submit', async(event) => {
    event.preventDefault();

    submitBtn.style.display = 'none';
    contactCloseBtn.style.display = 'none';
    cfTurnstile.style.display = 'none';
    submitSendingBtn.style.display = 'inline-block';

    const formData = new FormData(form);
    try {
        const response = await fetch(submitUrl, {
            method: "POST",
            body: JSON.stringify(Object.fromEntries(formData)),
            headers: {
                "Content-Type": "application/json",
            }
        })

        if (response.ok) {
            submitSendingBtn.style.display = 'none';
            modalForm.style.display = 'none';
            modalHeader.innerText = 'Thanks for contacting us!';
            successEmail.style.display = 'inline-block';
            successBtn.style.display = 'inline-block';
        } else {
            console.error('Error', response.status, response.statusText);
            submitSendingBtn.style.display = 'none';
            errorBtn.style.display = 'inline-block';
        }
    } catch (error) {
        console.error('Fetch error:', error)
        submitSendingBtn.style.display = 'none';
        errorBtn.style.display = 'inline-block';
    }
})

function ValidateForm() {

}