import React from 'react';

class FormattedMoney extends React.Component {

    constructor(props) {
        super(props);
     }

     format(amount) {
        return parseFloat(amount).toFixed(2)
     }

     render() {
        return (
           <span>Formatted money {this.format(this.props.value)}</span>
        );
     }
}

export default FormattedMoney;