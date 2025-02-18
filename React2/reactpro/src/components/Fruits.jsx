import Fruit from "./Fruit";
export default function Fruits() {
  //   const fruits = ["Apple", "Mango", "Banana", "Orange", "PineApple"];

  const fruits = [
    { name: "Apple", price: 10, soldout: false },
    { name: "Banana", price: 15, soldout: true },
    { name: "Orange", price: 5, soldout: false },
    { name: "PineApple", price: 25, soldout: true },
  ];
  return (
    <div>
      <ul>
        {fruits.map((fruit) => (
          <Fruit
            key={fruit.name}
            name={fruit.name}
            price={fruit.price}
            soldOut={fruit.soldout}
          />
        ))}
      </ul>
    </div>
  );
}
