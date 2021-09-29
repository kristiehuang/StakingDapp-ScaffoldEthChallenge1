import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="/" /*target="_blank" rel="noopener noreferrer"*/>
      <PageHeader
        title="🏗 mini 24-hour staker contract"
        subTitle="scaffold-eth challenge #1 [kristiehuang.eth]"
        style={{ cursor: "pointer" }}
      />
    </a>
  );
}
