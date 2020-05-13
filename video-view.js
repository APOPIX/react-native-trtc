import PropTypes from 'prop-types';
import { requireNativeComponent } from 'react-native';
import React from 'react';
class TRTCVideoView extends React.Component {
    render() {
        return <RNTVideoView {...this.props} />;
    }
}

TRTCVideoView.propTypes = {
    /**
     * A Boolean value that determines whether the user may use pinch
     * gestures to zoom in and out of the map.
     */
    zoomEnabled: PropTypes.bool,
};

var RNTVideoView = requireNativeComponent('RNTVideoView', TRTCVideoView);

module.exports = TRTCVideoView