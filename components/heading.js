// @flow
import React from 'react';

export default class extends React.Component {
  props: {
    title: any,
  };
  render() {
    const { title } = this.props;
    return (
      <div className="heading">
        <h1>{title}</h1>
      </div>
    );
  }
}
