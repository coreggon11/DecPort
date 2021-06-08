Moralis.initialize("DczXAfeIPRD026nJPsGKZNecQluiI7JwsXMwhPtE"); // Application id from moralis.io
Moralis.serverURL = "https://ehrhdrctvbal.moralis.io:2053/server"; //Server url from moralis.io

const CONTRACT_ADDRESS = "0x0B0aa55e4CF8371D43193f120eB68AB5552cb7F5";
const SHIB_ADDRESS = "0x6258D3497B01A273620Ed138d4F214661a283Eb4";
const SHIB_SUPPLY = 1000000000000000;

async function init() {
    try {
        let user = Moralis.User.current();
        if(!user){
            $("#login_button").click(async () => {
                user = await Moralis.Web3.authenticate();
            })
        }
        renderGame();
    } catch (error) {
        console.log(error);
    }
}

async function renderGame(){
   
}

init();