const terms = document.getElementById('terms-and-conditions');
const termsHeader = document.getElementById('terms-header');
const termsLink = document.getElementById('terms-link');
const privacy = document.getElementById('privacy-policy');
const privacyLink = document.getElementById('privacy-link');

termsLink.addEventListener('click', (e) => {
    e.preventDefault();
    privacy.style.display = 'none';
    termsHeader.innerHTML = 'Terms & Conditions';
    terms.style.display = 'inline-block';
})

privacyLink.addEventListener('click', (e) => {
    e.preventDefault();
    terms.style.display = 'none';
    termsHeader.innerHTML = 'Privacy Policy';
    privacy.style.display = 'inline-block';
})