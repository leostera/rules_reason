let component = ReasonReact.statelessComponent("Button");

let make = _children => {
  ...component,
  render: _self => <button> (ReasonReact.string("Hello!")) </button>,
};
