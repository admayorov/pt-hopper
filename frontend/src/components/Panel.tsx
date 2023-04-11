import React from 'react';

interface PanelProps {
  stopID: string;
}

const Panel: React.FC<PanelProps> = ({ stopID }) => {
  return <div className="w-full p-4 bg-gray-200">Stop ID #{stopID}</div>;
};

export default Panel;