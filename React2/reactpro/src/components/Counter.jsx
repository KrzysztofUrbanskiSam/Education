import { useState } from "react";

export default function Counter() {
  const [count, setCount] = useState(0);
  const [incrementBy, setIncrementBy] = useState(1);

  function handleIncrement() {
    setCount(count + incrementBy);
  }

  function handleDecrease() {
    setCount(count - incrementBy);
  }

  function increaseIncrement() {
    setIncrementBy(incrementBy + 1);
  }

  function decreaseIncrement() {
    setIncrementBy(incrementBy - 1);
  }

  return (
    <div>
      <h2>Count value is: {count}</h2>
      <button onClick={handleIncrement}>Increase Value</button>
      <button onClick={handleDecrease}>Decrease Value</button>

      <h2>We are incrementing by {incrementBy} </h2>
      <button onClick={increaseIncrement}>Increase Increment</button>
      <button onClick={decreaseIncrement}>Decrease Increment</button>
    </div>
  );
}
