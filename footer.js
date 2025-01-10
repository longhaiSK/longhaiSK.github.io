    // Get the current date and time
    const currentDate = new Date(document.lastModified);

    // Format the date as desired (e.g., "YYYY-MM-DD")
    const options = {  month: 'short', day: '2-digit', year: 'numeric'  };
    const canadaOptions = { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' 
      // hour: '2-digit', 
      // minute: '2-digit', 
      // second: '2-digit' 
    };

    const formattedDate = currentDate.toLocaleDateString('en-CA', canadaOptions); 

    // Display the date in the HTML
    document.getElementById('file-date').textContent = `This page was last modified on  ${formattedDate}. `; 