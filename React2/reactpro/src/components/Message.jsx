export default function Message() {
  function handleClick() {
    console.log("Button clicked");
  }

  return (
    <div>
      <button onClick={handleClick}>Click here to get Message</button>
    </div>
  );
}
