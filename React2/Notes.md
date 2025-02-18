# 3 Installation

```
npm create vite@4.1.0
cd reactpro
npm install
npm run dev
```

# 4 How React App works

Single page application. One index.html file but this file is empty.

So how react knows what to render?

```
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
```

In index.html there is src="path/to/main.jsx" which will execute script written in main.jsx, in main.jsx there is:

```
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
```

Line 'document.getElementById' finds div called 'root' and inside this DOM it will render <App/ > component

And in App component we have simple rendering page content like:

```
function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="App">
      <h1>React + React</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
      </div>
    </div>
  )
}

export default App
```

Rest of the files:

package.json -> all project dependencies. And also scripts which runs application

node_modules -> all modules which we currently use to run application (do not bother about content)

# 5 Creating a component

Component -> basic building block in react application

In terms of programming it has to be written in jsx or tsx files. It is javascript function that always has to return JSX component (traditional function returns data).

Components can be created anywhere but the best is to put them in src dir

Use component in code like:

```
<div className='App'>
    <Hello/>
</div>;
```

We can also close component like:

```
<Hello></Hello>
```

# 7 What is JSX in React?

JSX - Java Script eXtension - special syntax allows to combine HTML with JS.

What function returns is JSX code, to use JS syntax inside use {} brackets

```
const name= "Rob";
function Hello() {
  return <h1>Hello from a component {name}</h1>;
}
```

Rule of JSX:

- whenever you return you should return single element (syntax error) to overcome this, use single div element

```
  return (
    <div>
      <h1>
        Hello from a component {name} {displayMessage()}
      </h1>
      <h1>AAAA</h1>
    </div>
  );
```

# 8 Reusability of components

Just why we should use reusability.

# 9 What are Props in React

They make component dynamic. They are like parameters to function

React renders elements twice for development. We run app in React.StrictMode which executes app twice for safety reasons. It is done only in development mode

# 10 Destructuring of the props

'props' is an object. We canm destructre them like below:

Way #1

```
function Hello2(props) {
  const { name, message } = props;
```

The point is that destructured names has to be identical like in props.

Way #2 (preffered)

```
function Hello3({ name, message }) {
  return (<div>{message} {name} </div>);
}
```

# 11 Immutability of the props

Once you pass props to console you will get an error if try to assign value to prop

# 12 Pass arrays and objects to component

# 13 Rendering Arrays or lists in React

When create a new component try to make a habit to create component in that way:

```
export default function Fruits() {
    return <div></div>
}
```

To loop through iterables use 'map' like:

```
const prices = [10, 20 ,30 ,40]
prices.map((price, idx) => console.log(price, idx))

const discounts = prices.map((price) => (price * 0.32))

```

Explaination:
'price' -> the name of element we will have acces to. It can be inside curly brackets and it will still work, (price) => ()
'=>' -> arrow function (callback function)

# 14 Rendering Array of objects in React

To access properties of an object just use '.' dot operator.
To remember we cannot render object, just properties

# 15 Rendering components inside for loop

```
  <ul>
    {fruits.map((fruit) => (
      <Fruit key={fruit.name} name={fruit.name} price={fruit.price} />
    ))}
  </ul>
```

# 16 Conditionally rendering JSX components

Nothing special

# 17 Rendering components using Elements variable

Why we use Element components?
In react it is a good practice to avoid multiple return statements. Element variable can solve multiple returns but how?

Component variable is something like:

```
let messageOne = <h1>This is message 1</h1>;
```

In this video it was just said to define variable and change it basing on conditions. Finally in return statement return one variable/component

# 18 Using tenary operator

```
let isHappy = true
let message = isHappy ? "I am happy" : "I am not happy"
```

Example in React with JSX variable

```
  const component = display ? <Welcome /> : <Code />;
  return component;

  // Or In simpler way:
  return display ? <Welcome /> : <Code />;
```

# 19 Conditionally rendering list items

React Elements/Fragments.

If you are not sure if element from list will be printed it is better to encapsulate into 'empty divs' like:

```javascript
return (
  <>
    {price > 7 ? (
      <li>
        {name} {price}$
      </li>
    ) : (
      ""
    )}
  </>
);
```

And then in 'browser debug' no empty div will be presented

# 20 Conditionally render a message using ternary

Nothing special:

```javascript
<li>
  {name} {price}$ {soldout ? "Soldout" : ""}
</li>
```

# 21 Event handling in React

Interacting with website.
For buttons we need to define 'onClick' (NOTE it is JSX attribute)

```js
<button onClick={handleClick}>Click here to get Message</button>
```

Important: just pass the name of function. Do not use parenthesis

# 22 State in react

Props are immutable. But if you want change data dynamically use state. State is an object which holds the information controlling component.

Props:

- passed to component (like function parameter)
- immutable

State:

- is inside component
- can be changed (like variable inside component)

# 23 State in Raect example

State is like Component memory but can be changed?
Whenever any of state variable changes it causes component to re-render.

When you define state variable you have to use special function to modify state

State of the component should be declared at the top

# 24 Creating multiple states in React

What would happen if we would like to increment/decrement by something else then 1?

Nothing special. Just add one additional 'state variable'.

# 25 Handling input fields in React
