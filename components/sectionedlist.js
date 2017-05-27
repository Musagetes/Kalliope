// @flow

import React from 'react';
import type { SectionForRendering } from '../pages/helpers/types.js';

export default class extends React.Component {
  props: {
    sections: Array<SectionForRendering>,
  };
  render() {
    const { sections } = this.props;
    let renderedGroups = sections.map((group, i) => {
      const { title, items } = group;
      const list = items.map(item => {
        return (
          <div key={item.id}>
            <a href={item.url}>{item.html}</a>
          </div>
        );
      });
      return (
        <div className="list-section" key={i + title}>
          <h3>{title}</h3>
          {list}
        </div>
      );
    });
    return (
      <div className="two-columns">
        {renderedGroups}
      </div>
    );
  }
}
