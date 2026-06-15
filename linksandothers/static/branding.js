function makeItRainbow() {
    if (typeof confetti === 'function') {
        confetti({
            particleCount: 100,
            spread: 70,
            origin: { y: 0.6 },
            shapes: ['star'],
            colors: ['#37d478', '#1abc9c', '#223ce6']
        });
    }
}