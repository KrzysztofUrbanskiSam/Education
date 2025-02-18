import Code from "./Code";
import Welcome from "./Welcome";

export default function ConditionalComponent() {
  const display = false;

  // 1 Not recommended
  //   if (display) {
  //     return <Welcome />
  //   } else {
  //     return <Code />
  //   }

  // 2 recommended
  // let component;
  // if (display) {
  //   component = <Welcome />;
  // } else {
  //   component = <Code />;
  // }

  // 3 Using tenary operator
  return display ? <Welcome /> : <Code />;
}
