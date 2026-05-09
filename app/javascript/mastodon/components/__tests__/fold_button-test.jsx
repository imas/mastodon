import renderer from 'react-test-renderer';

import { render, fireEvent, screen } from '@/testing/rendering';

import FoldButton from '../fold_button';

describe('<FoldButton />', () => {
  it('renders a button element with default props', () => {
    const tree = renderer.create(<FoldButton size={20} title='toggle' />).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('rotates icon 180deg when active', () => {
    const tree = renderer.create(<FoldButton size={20} title='toggle' active />).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('applies transition styles when animate is true', () => {
    const tree = renderer.create(<FoldButton size={20} title='toggle' active animate />).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('calls onClick handler when clicked', () => {
    const handler = vi.fn();
    render(<FoldButton size={20} title='toggle' onClick={handler} />);
    fireEvent.click(screen.getByTitle('toggle'));
    expect(handler).toHaveBeenCalledTimes(1);
  });

  it('does not call onClick when disabled', () => {
    const handler = vi.fn();
    render(<FoldButton size={20} title='toggle' onClick={handler} disabled />);
    fireEvent.click(screen.getByTitle('toggle'));
    expect(handler).not.toHaveBeenCalled();
  });

  it('prevents default on click', () => {
    const handler = vi.fn();
    render(<FoldButton size={20} title='toggle' onClick={handler} />);
    const event = new MouseEvent('click', { bubbles: true, cancelable: true });
    fireEvent(screen.getByTitle('toggle'), event);
    expect(event.defaultPrevented).toBe(true);
  });
});
