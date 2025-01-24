// import './App.css'
import { Hello, Hello2, Hello3, Hello4 } from "./components/Hello";

function App() {
  // const [count, setCount] = useState(0)
  const seatNumbers = [1, 4, 7];
  const person = {
    name: 'Kris',
    message: 'Hi person',
    seatNumbers: [1, 2, 3]
  }
  return (
    <div className="App">
      <Hello />
      <Hello2 message="HI," name="Rob 2" />
      <Hello2 name="Kris" />
      <Hello3 name="Ann" message="Witaj" seatNumbers={seatNumbers}/>
      <Hello4 person={person}/>
    </div>
  );
}

export default App;
