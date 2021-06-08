Moralis.initialize("DczXAfeIPRD026nJPsGKZNecQluiI7JwsXMwhPtE"); // Application id from moralis.io
Moralis.serverURL = "https://ehrhdrctvbal.moralis.io:2053/server"; //Server url from moralis.io

const CONTRACT_ADDRESS = "0x0B0aa55e4CF8371D43193f120eB68AB5552cb7F5";

var addedTokens = 0;

async function init() {

    Moralis.Web3.getSigningData = () => 'Connect Metamask to DecPort'

    try {
        let user = Moralis.User.current();

        if(user.authenticated() && ethereum.selectedAddress) {
            initWhenLogged();
        } else {
            $("#login_button").click(async () => {
                user = await Moralis.Web3.authenticate();
                if(user) {
                    initWhenLogged();
                }
            })
        }
        render();
    } catch (error) {
        console.log(error);
    }
}

function initWhenLogged(){
    $("#login_button").hide();
    $("#address").html(ethereum.selectedAddress);

    $("#button-add-token").click(() => {
        addToken();
    });
}

function addToken(){
    console.log("Add token")
    $("#tokens").append(getTokenString())
    let id = addedTokens - 1;
    $(`#remove-token-${id}`).click(()=>{
        $(`#token-${id}`).remove();
    })
}

function getTokenString(){
    return  `<div class="row row-token" id="token-${addedTokens}">
    <div class="col-md-6">
      Token address
      <input type="text" class="token-address">
    </div>
    <div class="col-md-7">
      Token % share in portfolio
      <input type="text" class="token-address">
    </div>
    <div class="col-md-7">
    <button id="remove-token-${addedTokens++}">Remove token</button>
    </div>
  </div>`;
}

async function render(){
   
}

init();