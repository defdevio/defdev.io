let submitUrl = "https://vh4tf5xws5.execute-api.us-west-2.amazonaws.com/prod/contact";
const form = document.getElementById('contact');
form.addEventListener('submit', async(event) => {
    event.preventDefault();
    const formData = new FormData(form);
    try {
        const response = await fetch(submitUrl, {
            method: "POST",
            body: JSON.stringify(Object.fromEntries(formData)),
            mode: 'no-cors',
            headers: {
                "Content-Type": "application/json",
            }
        })

        if (response.ok) {
            const result = await response.json();
            console.log('Success', result);
        } else {
            console.error('Error', response.status, response.statusText);
        }
    } catch (error) {
        console.error('Fetch error:', error)
    }
})
