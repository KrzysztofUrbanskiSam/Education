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