import React from 'react';
import Results from './components/Results';
import Cliqz from './services/cliqz-wrapper';

export default class SearchResults extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      results: {},
      query: '',
      theme: this.props.theme,
    };
    this.searchRef = React.createRef();
    this.onAction = this.onAction.bind(this);
    this.onResults = this.onResults.bind(this);
    this.cliqz = new Cliqz(this.props.bridgeManager.inject)
  }

  onResults(results) {
    this.setState({ results });
  }

  onAction({ module, action, args, id }) {
    if (module === 'search' && action === 'startSearch') {
      const query = args[0];
      this.setState({ query });
    }

    if (module === 'search' && action === 'stopSearch') {
      this.setState({
        results: {
          results: [],
          meta: {},
        },
      });
    }

    if (module === 'Screen:SearchResults' && action === 'changeTheme') {
      this.setState({
        theme: args[0],
      });
      return true;
    }
  }

  componentWillMount() {
    this.props.bridgeManager.addActionListener(this.onAction);
    this.props.events.sub('search:results', this.onResults);
  }

  componentWillUnmount() {
    this.props.bridgeManager.removeActionListener(this.onAction);
    this.props.events.un_sub('search:results', this.onResults);
  }

  render() {
    return (
      <Results
        results={this.state.results}
        query={this.state.query}
        cliqz={this.cliqz}
        theme={this.state.theme}
      />
    );
  }
};