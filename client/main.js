Moralis.initialize("DczXAfeIPRD026nJPsGKZNecQluiI7JwsXMwhPtE"); // Application id from moralis.io
Moralis.serverURL = "https://ehrhdrctvbal.moralis.io:2053/server"; //Server url from moralis.io

const CONTRACT_ADDRESS = "0x0B0aa55e4CF8371D43193f120eB68AB5552cb7F5";

async function init() {

    Moralis.Web3.getSigningData = () => 'Connect Metamask to DecPort'

    try {
        let user = Moralis.User.current();

        if(user.authenticated() && ethereum.selectedAddress) {
            hideLoginButton();
        } else {
            $("#login_button").click(async () => {
                user = await Moralis.Web3.authenticate();
                if(user) {
                    hideLoginButton();
                }
            })
        }
        render();
    } catch (error) {
        console.log(error);
    }
}

function hideLoginButton(){
    $("#login_button").hide();
    $("#address").html(ethereum.selectedAddress);
}

async function render(){
   
}

init();