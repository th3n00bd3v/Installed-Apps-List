document.addEventListener('DOMContentLoaded', function() {
    const table = document.querySelector('table');
    const headers = table.querySelectorAll('th');
    let isAscending = true;

    headers.forEach((header, index) => {
        header.addEventListener('click', () => {
            const rowsArray = Array.from(table.querySelectorAll('tbody tr'));
            const isSortedAsc = header.classList.contains('sorted-asc');
            
            rowsArray.sort((a, b) => {
                const aText = a.children[index].textContent.trim();
                const bText = b.children[index].textContent.trim();
                let aValue = aText;
                let bValue = bText;

                if (index === 3) {
                    aValue = parseFloat(aText.replace(/[^0-9.]/g, '')) || 0;
                    bValue = parseFloat(bText.replace(/[^0-9.]/g, '')) || 0;
                } else if (index === 4) {
                    aValue = Date.parse(aText) || 0;
                    bValue = Date.parse(bText) || 0;
                }

                return isAscending 
                    ? (aValue > bValue ? 1 : aValue < bValue ? -1 : 0)
                    : (aValue < bValue ? 1 : aValue > bValue ? -1 : 0);
            });

            isAscending = !isAscending;
            headers.forEach(th => th.classList.remove('sorted-asc', 'sorted-desc'));
            header.classList.add(isAscending ? 'sorted-asc' : 'sorted-desc');

            const tbody = table.querySelector('tbody');
            rowsArray.forEach(row => tbody.appendChild(row));
        });
    });
});
