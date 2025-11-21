
window.addEventListener("message", function(e){
    if(e.data.action === "open"){
        document.body.style.display = "block";
    }
    if(e.data.action === "close"){
        document.body.style.display = "none";
    }
});

document.querySelectorAll(".mode").forEach(btn=>{
    btn.addEventListener("click", ()=>{
        fetch(`https://${GetParentResourceName()}/selectMode`, {
            method: "POST",
            body: JSON.stringify({ mode: btn.dataset.mode })
        });
    });
});
document.body.style.display = "none";
