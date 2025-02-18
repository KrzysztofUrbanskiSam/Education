// import './App.css'
import ConditionalComponent from "./components/ConditionalComponent";
import Fruits from "./components/Fruits";
import { Hello, Hello2, Hello3, Hello4 } from "./components/Hello";
import Counter from "./components/Counter";
import Message from "./components/Message";

function App() {
  // const [count, setCount] = useState(0)
  const seatNumbers = [1, 4, 7];
  const person = {
    name: "Kris",
    message: "Hi person",
    seatNumbers: [1, 2, 3],
  };
  return (
    <div className="App">
      <Fruits />
      {/* <Message /> */}
      <Counter />
    </div>
  );
}

export default App;
