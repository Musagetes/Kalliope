// @flow

import React from 'react';
import PictureOverlay from './pictureoverlay.js';
import { Link, Router } from '../routes';
import type { PictureItem, Lang } from '../pages/helpers/types.js';

type MainStateTypes = {
  overlayPictures: {
    pictures: Array<PictureItem>,
    startIndex: number,
    lang: Lang,
  } | null,
};
export default class Main extends React.Component<*, MainStateTypes> {
  static childContextTypes = {
    showPictureOverlay: Function,
    hidePictureOverlay: Function,
  };

  hidePictureOverlay: () => void;
  showPictureOverlay: () => void;

  constructor(props: *) {
    super(props);
    this.hidePictureOverlay = this.hidePictureOverlay.bind(this);
    this.showPictureOverlay = this.showPictureOverlay.bind(this);
    this.state = {
      overlayPictures: null,
    };
  }

  getChildContext() {
    return {
      showPictureOverlay: this.showPictureOverlay.bind(this),
      hidePictureOverlay: this.hidePictureOverlay.bind(this),
    };
  }

  showPictureOverlay(
    pictures: Array<PictureItem>,
    lang: Lang,
    startIndex: number = 0
  ) {
    this.setState({
      overlayPictures: { pictures, lang, startIndex },
    });
  }
  hidePictureOverlay() {
    this.setState({ overlayPictures: null });
  }

  render() {
    const { overlayPictures } = this.state;

    let overlay = null;
    if (overlayPictures != null) {
      const { pictures, startIndex, lang } = overlayPictures;
      overlay = (
        <PictureOverlay
          pictures={pictures}
          startIndex={startIndex}
          lang={lang}
          clickToZoom={false}
          closeCallback={this.hidePictureOverlay}
        />
      );
    }

    return (
      <div>
        {overlay}
        {this.props.children}
        <style jsx>{`
          div {
            max-width: 880px;
            margin: 0px auto;
            padding: 0 20px;
          }
        `}</style>
      </div>
    );
  }
}
