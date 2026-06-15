(function () {
    const menuButton = document.getElementById('navMenuBtn');
    const sidebar = document.getElementById('appSidebar');

    if (menuButton && sidebar) {
        menuButton.addEventListener('click', function () {
            const isOpen = sidebar.classList.toggle('is-open');
            menuButton.classList.toggle('is-active', isOpen);
            menuButton.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        });
    }

    document.querySelectorAll('.nav-dropdown-btn').forEach(function (button) {
        button.addEventListener('click', function () {
            const dropdown = button.closest('.nav-dropdown');
            if (!dropdown) return;
            const isOpen = dropdown.classList.toggle('is-open');
            button.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        });
    });

    document.addEventListener('click', function (event) {
        if (event.target.closest('.nav-dropdown')) return;
        document.querySelectorAll('.nav-dropdown.is-open').forEach(function (dropdown) {
            dropdown.classList.remove('is-open');
            const button = dropdown.querySelector('.nav-dropdown-btn');
            if (button) button.setAttribute('aria-expanded', 'false');
        });
    });
}());
