const name = "Rob";

function displayMessage() {
  return "Wow!";
}

function Hello() {
  return (
    <div>
      <h1>
        Hello {name} {displayMessage()}
      </h1>
    </div>
  );
}

// Destructure object inside component
function Hello2(props) {
  console.log(props); // Will print {} dict with properties
  const { name, message } = props;
  return (
    <div>
      <h1>
        {message} {name}
      </h1>
    </div>
  );
}

// Destructure object in arguments - which is mostly used
function Hello3({ name, message, seatNumbers }) {
  return (
    <div>
      <h1>
        {message} {name} {seatNumbers}
      </h1>
    </div>
  );
}


function Hello4(props) {
  return (
    <div>
      <h1>
        {props.person.message} {props.person.name} {props.person.seatNumbers}
      </h1>
    </div>
  );
}

export { Hello, Hello2, Hello3, Hello4 };
