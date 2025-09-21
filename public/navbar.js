document.addEventListener('DOMContentLoaded', () => {
  const navbar = document.querySelector('.navbar');
  if (!navbar) {
    return;
  }

  const dropdowns = Array.from(navbar.querySelectorAll('.navbar-item.dropdown'));

  const closeDropdown = (dropdown) => {
    dropdown.classList.remove('open');
    dropdown.querySelectorAll('.dropdown-submenu.open').forEach((submenu) => {
      submenu.classList.remove('open');
    });
  };

  const closeAllDropdowns = () => {
    dropdowns.forEach(closeDropdown);
  };

  dropdowns.forEach((dropdown) => {
    const trigger = dropdown.querySelector('.dropbtn');
    if (!trigger) {
      return;
    }

    trigger.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();

      const isOpen = dropdown.classList.contains('open');
      closeAllDropdowns();

      if (!isOpen) {
        dropdown.classList.add('open');
      }
    });
  });

  const submenus = Array.from(navbar.querySelectorAll('.dropdown-submenu'));

  submenus.forEach((submenu) => {
    const trigger = submenu.querySelector('.submenu-btn, .dropbtn');
    if (!trigger) {
      return;
    }

    trigger.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();

      const isOpen = submenu.classList.contains('open');

      Array.from(submenu.parentElement.children)
        .filter((element) => element !== submenu && element.classList.contains('dropdown-submenu'))
        .forEach((element) => element.classList.remove('open'));

      if (isOpen) {
        submenu.classList.remove('open');
      } else {
        submenu.classList.add('open');
      }
    });
  });

  document.addEventListener('click', (event) => {
    if (!event.target.closest('.navbar')) {
      closeAllDropdowns();
    }
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      closeAllDropdowns();
    }
  });
});
