//
//  main.js
//
//  Created by Markus Sprunck on 19.10.2016
//  Copyright © 2016-2018 Markus Sprunck. All rights reserved.
//

// Konstanten (werden nicht verändert)
MAXIMALE_ANZAHL_LUFTBALLONS  = 99;
ANZAHL_LUFTBALLONS = 5;

// Zähler (werden beim Spielen verändert)
var anzahl_gepatzte_luftballons = 0;
var anzahl_erzeugter_luftballons = 0;

// Der Timer ist wie ein Wecker der alle n-millisekunden eine Funktion aufruft
var timer;

// Wenn das Spiel fertig ist, wird der Wert auf true gesetzt
var istSpielFertig = false

// Diese Funktion wird aufgerufen wenn der Timer "klingelt"
function timerFunktion() {
    
    for (var nummer = 1; nummer <= ANZAHL_LUFTBALLONS; nummer++) {
        
        istSpielFertig = MAXIMALE_ANZAHL_LUFTBALLONS <= anzahl_erzeugter_luftballons
        
        var kreis = document.getElementById("C" + nummer);
        var linie = document.getElementById("L" + nummer);
        
        var y_alt = parseInt(kreis.getAttribute("cy"));
        var x_alt = parseInt(kreis.getAttribute("cx"));
        var r_alt = parseInt(kreis.getAttribute("r"));
        var schrittWeite = 3 + r_alt / 6;
        if (y_alt + r_alt * 5 > 0 && r_alt > 1) {
            
            // Solange noch Luftballone sichtbar sind ist das Spiel noch nicht fertig
            istSpielFertig = false
            
            // Bewege den Luftballon und die Schnur ein Stück nach oben
            var y_neu = y_alt - schrittWeite;
            kreis.setAttribute("cy", y_neu);
            linie.setAttribute("y1", y_neu + r_alt);
            linie.setAttribute("y2", y_neu + r_alt * 5);
            
            // Bewege den Luftballon und die Schnur ein Stück nach rechts
            var x_neu = x_alt + schrittWeite / 10;
            kreis.setAttribute("cx", x_neu);
            linie.setAttribute("x1", x_neu );
            linie.setAttribute("x2", x_neu );
            
        } else if (!istSpielFertig) {
            
            // Fange unten wieder an
            var y_neu = window.innerHeight;
            kreis.setAttribute("cy", y_neu);
            linie.setAttribute("y1", y_neu + r_alt);
            linie.setAttribute("y2", y_neu + r_alt * 5);
            
            // Wähle eine zufällige x-Koorniate
            var x_neu = document.body.clientWidth * Math.random();
            kreis.setAttribute("cx", x_neu);
            linie.setAttribute("x1", x_neu);
            linie.setAttribute("x2", x_neu);
            
            // Wähle einen zufälligen Radius für den Ballon
            kreis.setAttribute("r", 40 + 60 * Math.random());
            
            anzahl_erzeugter_luftballons = anzahl_erzeugter_luftballons + 1
        }
    }
    
    if (istSpielFertig) {
        clearInterval(timer);
        timer = false
        
        // Schreibe das Ergebnis in die Titelzeile der App
        updateLabel("Result: " + anzahl_gepatzte_luftballons + " of " + anzahl_erzeugter_luftballons + " balloons");
    } else {
        // Schreibe das Zwischenergebnis in die Titelzeile der App
        updateLabel("" + anzahl_gepatzte_luftballons + " of " + anzahl_erzeugter_luftballons + " balloons");
    }
}


// Diese Funktion wird aufgerufen, wenn man auf einen Luftballon tippt
function circle_click(evt) {
    
    // Nur wenn das Spiel aktive ist soll es möglich sein zu klicken
    if (timer && anzahl_gepatzte_luftballons < MAXIMALE_ANZAHL_LUFTBALLONS) {
        
        // der Kreis auf den geklickt wurde
        var circle = event.touches[0].target;
        
        // setze den Radius auf Null, dass der Ballon unsichtbar wird
        circle.setAttribute("r", 0);
        
        // mach die Leine unsichtbar
        var nummer = circle.id[1];
        var linie = document.getElementById("L" + nummer);
        linie.setAttribute("x1", 0);
        linie.setAttribute("x2", 0);
        
        // der Zähler für anzahl_gepatzte_luftballons wird um Eins erhöht
        anzahl_gepatzte_luftballons = anzahl_gepatzte_luftballons + 1;
        
        log("Ballon with id=" + circle.id + " popped")
    }
}


// Ruft in der App eine Funktion auf und schreibt die Titelzeile den übergebenen text
function updateLabel(value) {
    try {
        webkit.messageHandlers.callbackHandlerStatusLabel.postMessage("" + value);
    } catch (err) {
        console.log('ERROR: The native context does not exist yet');
    }
}


// Wird von der App aufgerufen, wenn der Play Button gedrückt wurde
function startGame() {
    clearInterval(timer);
    timer = setInterval(timerFunktion, 50)
    log("Game started")
}


// Wird von der App aufgerufen, wenn der Löschen Button gedrückt wurde
function resetGame() {
    updateLabel("Pop the " + MAXIMALE_ANZAHL_LUFTBALLONS + " ballons")
    log("Game reset")
}


// Wird von der App aufgerufen, wenn der Pause Button gedrückt wurde
function stopGame() {
    clearInterval(timer);
    timer = false
    log("Game stop")
}


// Ruft in der App eine Funktion auf und schreibt den übergebenen text in die console
function log(value) {
    try {
        webkit.messageHandlers.callbackHandlerLogging.postMessage("WEB " + value);
    } catch (err) {
        console.log('ERROR: The native context does not exist yet');
    }
}
