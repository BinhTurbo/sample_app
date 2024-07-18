document.addEventListener("turbo:load", function () {
	let account = document.querySelector(".dropdown-toggle");

	if (account) {
		account.addEventListener("click", function (event) {
			event.preventDefault();

			let menu = document.querySelector(".dropdown-menu");

			if (menu) {
				menu.classList.toggle("active");
			}
		});
	}
});
